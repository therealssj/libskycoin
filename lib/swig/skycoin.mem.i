%newobject wrap_SKY_cipher_GenerateDeterministicKeyPairs;
%newobject wrap_SKY_cipher_GenerateDeterministicKeyPairsSeed;
%typemap(newfree) cipher_SecKeys* "destroy_cipher_SecKeys($1);";
%typemap(newfree) cipher_PubKeys* "destroy_cipher_PubKeys($1);";


//returning error code is sacrificed in order to return an allocate object that can be garbage collected
%rename(SKY_cipher_GenerateDeterministicKeyPairs) wrap_SKY_cipher_GenerateDeterministicKeyPairs;
%inline {
	cipher_SecKeys* wrap_SKY_cipher_GenerateDeterministicKeyPairs(GoSlice seed, GoInt n){
		cipher_SecKeys* secKeys;
		secKeys = malloc(sizeof(cipher_SecKeys));
		memset(secKeys, 0, sizeof(cipher_SecKeys));
		GoSlice_ data;
		data.data = NULL;
		data.len = 0;
		data.cap = 0;
		GoUint32 result = SKY_cipher_GenerateDeterministicKeyPairs(seed, n, &data);
		if( result == 0 ){
			secKeys->count = data.len;
			secKeys->data = data.data;
		}
		return secKeys;
	}
}


%rename(SKY_cipher_GenerateDeterministicKeyPairsSeed) wrap_SKY_cipher_GenerateDeterministicKeyPairsSeed;
%inline {
	cipher_SecKeys* wrap_SKY_cipher_GenerateDeterministicKeyPairsSeed(GoSlice seed, GoInt n, coin__UxArray* newSeed){
		cipher_SecKeys* secKeys;
		secKeys = malloc(sizeof(cipher_SecKeys));
		memset(secKeys, 0, sizeof(cipher_SecKeys));
		GoSlice_ data;
		data.data = NULL;
		data.len = 0;
		data.cap = 0;
		GoUint32 result = SKY_cipher_GenerateDeterministicKeyPairsSeed(seed, n, newSeed, &data);
		if( result == 0 ){
			secKeys->count = data.len;
			secKeys->data = data.data;
		}
		return secKeys;
	}
}


%rename(SKY_cipher_PubKeySlice_Len) wrap_SKY_cipher_PubKeySlice_Len;
%inline {
	//[]PubKey
	GoUint32 wrap_SKY_cipher_PubKeySlice_Len(cipher_PubKeys* pubKeys){
		GoSlice_ data;
		data.data = pubKeys->data;
		data.len = pubKeys->count;
		data.cap = pubKeys->count;
		GoUint32 result = SKY_cipher_PubKeySlice_Len(&data);
		return result;
	}
}

%rename(SKY_cipher_PubKeySlice_Less) wrap_SKY_cipher_PubKeySlice_Less;
%inline {
	GoUint32 wrap_SKY_cipher_PubKeySlice_Less(cipher_PubKeys* pubKeys, GoInt p1, GoInt p2){
		GoSlice_ data;
		data.data = pubKeys->data;
		data.len = pubKeys->count;
		data.cap = pubKeys->count;
		GoUint32 result = SKY_cipher_PubKeySlice_Less(&data, p1, p2);
		return result;
	}
}

%rename(SKY_cipher_PubKeySlice_Swap) wrap_SKY_cipher_PubKeySlice_Swap;
%inline {
	GoUint32 wrap_SKY_cipher_PubKeySlice_Swap(cipher_PubKeys* pubKeys, GoInt p1, GoInt p2){
		GoSlice_ data;
		data.data = pubKeys->data;
		data.len = pubKeys->count;
		data.cap = pubKeys->count;
		GoUint32 result = SKY_cipher_PubKeySlice_Swap(&data, p1, p2);
		return result;
	}
}

/**
*
* typemaps for Handles
*
**/


/* Handle reference typemap. */
%typemap(in, numinputs=0) Handle* (Handle temp) {
	$1 = &temp;
}

/* Handle out typemap. */
%typemap(argout) Handle* {
	%append_output( SWIG_From_long(*$1) );
}

/* Handle not as pointer is input. */
%typemap(in) Handle {
	SWIG_AsVal_long($input, (long*)&$1);
}


%apply Handle { Wallet__Handle, Options__Handle, ReadableEntry__Handle, ReadableWallet__Handle, WebRpcClient__Handle,
	WalletResponse__Handle, Client__Handle, Strings__Handle, Wallets__Handle, Config__Handle, App__Handle, Context__Handle,
	GoStringMap, PasswordReader__Handle_,
	Transaction__Handle, Transactions__Handle, CreatedTransaction__Handle,
	CreatedTransactionOutput__Handle, CreatedTransactionInput__Handle, CreateTransactionResponse__Handle,
	Block__Handle, SignedBlock__Handle, BlockBody__Handle
	}

%apply Handle* { Wallet__Handle*, Options__Handle*, ReadableEntry__Handle*, ReadableWallet__Handle*, WebRpcClient__Handle*,
	WalletResponse__Handle*, Client__Handle*, Strings__Handle*, Wallets__Handle*, Config__Handle*,
	App__Handle*, Context__Handle*, GoStringMap_*, PasswordReader__Handle*,
	Transaction__Handle*, Transactions__Handle*, CreatedTransaction__Handle*,
	CreatedTransactionOutput__Handle*, CreatedTransactionInput__Handle*, CreateTransactionResponse__Handle*,
	Block__Handle*, SignedBlock__Handle*, BlockBody__Handle*
	}
