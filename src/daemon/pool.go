package daemon

import (
    "github.com/skycoin/gnet"
    "github.com/skycoin/skycoin/src/util"
    "log"
    "time"
)

type PoolConfig struct {
    // Timeout when trying to connect to new peers through the pool
    DialTimeout time.Duration
    // How often to process message buffers and generate events
    MessageHandlingRate time.Duration
    // How long to wait before sending another ping
    PingRate time.Duration
    // How long a connection can idle before considered stale
    IdleLimit time.Duration
    // How often to check for needed pings
    IdleCheckRate time.Duration
    // How often to check for stale connections
    ClearStaleRate time.Duration
    // Buffer size for gnet.ConnectionPool's network Read events
    EventChannelBufferSize int
    // These should be assigned by the controlling daemon
    address string
    port    int
}

func NewPoolConfig() PoolConfig {
    defIdleLimit := time.Minute * 90
    return PoolConfig{
        port:                   6677,
        address:                "",
        DialTimeout:            time.Second * 30,
        MessageHandlingRate:    time.Millisecond * 30,
        PingRate:               defIdleLimit / 3,
        IdleLimit:              defIdleLimit,
        IdleCheckRate:          time.Minute,
        ClearStaleRate:         time.Minute,
        EventChannelBufferSize: 4096,
    }
}

type Pool struct {
    Config PoolConfig
    Pool   *gnet.ConnectionPool
}

func NewPool(c PoolConfig) *Pool {
    return &Pool{
        Config: c,
        Pool:   nil,
    }
}

// Begins listening on port for connections and periodically scanning for
// messages on read_interval
func (self *Pool) Init(d *Daemon) {
    logger.Info("InitPool on port %d", self.Config.port)
    cfg := gnet.NewConfig()
    cfg.DialTimeout = self.Config.DialTimeout
    cfg.Port = uint16(self.Config.port)
    cfg.Address = self.Config.address
    cfg.ConnectCallback = d.onGnetConnect
    cfg.DisconnectCallback = d.onGnetDisconnect
    cfg.EventChannelBufferSize = cfg.EventChannelBufferSize
    pool := gnet.NewConnectionPool(cfg, d)
    self.Pool = pool
}

// Closes all connections and stops listening
func (self *Pool) Shutdown() {
    if self.Pool != nil {
        self.Pool.StopListen()
        logger.Info("Shutdown pool")
    }
}

// Starts listening on the configured Port
func (self *Pool) Start() {
    if err := self.Pool.StartListen(); err != nil {
        log.Panic(err)
    }
}

// Send a ping if our last message sent was over pingRate ago
func (self *Pool) sendPings() {
    now := util.Now()
    for _, c := range self.Pool.Pool {
        if c.LastSent.Add(self.Config.PingRate).Before(now) {
            err := self.Pool.Dispatcher.SendMessage(c, &PingMessage{})
            if err != nil {
                logger.Warning("Failed to send ping message to %s", c.Addr())
            }
        }
    }
}

// Removes connections that have not sent a message in too long
func (self *Pool) clearStaleConnections() {
    now := util.Now()
    for _, c := range self.Pool.Pool {
        if c.LastReceived.Add(self.Config.IdleLimit).Before(now) {
            self.Pool.Disconnect(c, DisconnectIdle)
        }
    }
}