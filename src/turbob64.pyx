# distutils: extra_compile_args = /O3 /arch:AVX /arch:AVX2 /arch:AVX512

'''
Copyright (C) powturbo 2016-2023
Python bindings by daijro
'''

from libc.stdlib cimport free, malloc


ctypedef unsigned char uchar

cdef extern from "turbob64.h":
    # ==== Turbo-Base64 API functions ==== #
	
	# Return the base64 buffer length after encoding
    cdef size_t tb64enclen(size_t inlen)

    # Return the original (after decoding) length for a given base64 encoded buffer
    cdef size_t tb64declen(const uchar* in_, size_t inlen)

    # Define a function pointer for all encoding/decoding functions
    ctypedef size_t (*TB64FUNC)(const uchar* in_, size_t inlen, uchar* out)

	# Return the original (after decoding) length for a given base64 encoded buffer
    # Encode binary input 'in' buffer into base64 string 'out' 
    # with automatic cpu detection for avx2/sse4.1/scalar 
    # in          : Input buffer to encode
    # inlen       : Length in bytes of input buffer
    # out         : Output buffer
    # return value: Length of output buffer
    # Remark      : byte 'zero' is not written to end of output stream
    #             Caller must add 0 (out[outlen] = 0) for a null terminated string
    cdef TB64FUNC tb64enc

    # ==== Direct call to tb64enc + tb64dec ==== #
    
    # Direct call to tb64enc + tb64dec saving a function call + a check instruction
    # call tb64ini, then call _tb64e(in, inlen, out) or _tb64d(in, inlen, out)
    cdef TB64FUNC _tb64e
    cdef TB64FUNC _tb64d

    # Decode base64 input 'in' buffer into binary buffer 'out' 
    # in          : input buffer to decode
    # inlen       : length in bytes of input buffer 
    # out         : output buffer
    # return value: >0 output buffer length
    #                0 Error (invalid base64 input or input length = 0)
    cdef TB64FUNC tb64dec
	
    # ==== Base64 Internal functions ==== #

    # Memory efficient (small lookup tables) scalar but (slower) version
    cdef TB64FUNC tb64senc
    cdef TB64FUNC tb64sdec
    
    # Fast scalar
    cdef TB64FUNC tb64xenc
    cdef TB64FUNC tb64xdec

    # ssse3
    cdef TB64FUNC tb64v128enc
    cdef TB64FUNC tb64v128dec

    # avx
    cdef TB64FUNC tb64v128aenc
    cdef TB64FUNC tb64v128adec

    # avx2
    cdef TB64FUNC tb64v256enc
    cdef TB64FUNC tb64v256dec

    # avx512_vbmi
    cdef TB64FUNC tb64v512enc
    cdef TB64FUNC tb64v512dec

    # detect cpu && set the default run time functions for tb64enc/tb64dec
    # isshort = 0 : default
    # isshort > 0 : set optimized short strings version (actually only avx2)
    cdef void tb64ini(unsigned int id, unsigned int isshort)

    # ==== Optimized functions for short strings only ==== #

    # decoding without checking  
    # can read beyond the input buffer end, 
    # therefore input buffer size must be 32 bytes larger than input length
    cdef TB64FUNC _tb64v256enc
    cdef TB64FUNC _tb64v256dec

    # ==== CPU instruction set ==== #

    # cpuisa  = 0: return current simd set, 
    # cpuisa != 0: set simd set 0:scalar, 0x33:sse2, 0x60:avx2
    cdef unsigned int cpuini(unsigned int cpuisa)

    # convert simd set to string "sse3", "ssse3", "sse4.1", "avx", "avx2", "neon",... 
    # Ex.: printf("current cpu set=%s\n", cpustr(cpuini(0)) ); 
    cdef char* cpustr(unsigned int cpuisa)


# Set the default run time functions for tb64enc/tb64dec
tb64ini(0, 0)
cpu_set = cpuini(0)

# print("current cpu set = ", cpustr(cpu_set)); 
# print("short supported = ", cpu_set >= 0x60); 


# == public API == #

class InvalidCPUError(Exception):
    # Invalid CPU arch type exception
    pass


cpdef b64encode(bytes input_):
    cdef size_t inlen = len(input_)
    cdef size_t outlen = tb64enclen(inlen)
    # use the short string optimized version
    return _transform(
        input_,
        _tb64v256enc if inlen < 2000 and cpu_set == 0x60 else _tb64e,
        inlen,
        outlen
    )


cpdef b64decode(bytes input_):
    cdef size_t inlen = len(input_)
    cdef size_t outlen = tb64declen(<uchar*> input_, inlen)
    if outlen == 0 and inlen != 0:
        raise ValueError("Invalid input")
    return _transform(
        input_,
        # use the short string optimized version
        _tb64v256dec if inlen < 2000 and cpu_set == 0x60 else _tb64d,
        inlen,
        outlen
    )


# == other shortcuts to turbob64 functions == #

# Memory efficient (small lookup tables) scalar (slower)
cpdef b64senc(bytes input_):
    return _b64enc(input_, tb64senc)

cpdef b64sdec(bytes input_):
    return _b64dec(input_, tb64sdec)

# Fast scalar
cpdef b64xenc(bytes input_):
    return _b64enc(input_, tb64xenc)

cpdef b64xdec(bytes input_):
    return _b64dec(input_, tb64xdec)

# ssse3
cpdef b64v128enc(bytes input_):
    if cpu_set < 0x32: raise InvalidCPUError("ssse3 is not supported")
    return _b64enc(input_, tb64v128enc)

cpdef b64v128dec(bytes input_):
    if cpu_set < 0x32: raise InvalidCPUError("ssse3 is not supported")
    return _b64dec(input_, tb64v128dec)

# avx
cpdef b64v128aenc(bytes input_):
    if cpu_set < 0x50: raise InvalidCPUError("avx is not supported")
    return _b64enc(input_, tb64v128aenc)

cpdef b64v128adec(bytes input_):
    if cpu_set < 0x50: raise InvalidCPUError("avx is not supported")
    return _b64dec(input_, tb64v128adec)

# avx2
cpdef b64v256enc(bytes input_):
    if cpu_set < 0x60: raise InvalidCPUError("avx2 is not supported")
    return _b64enc(input_, tb64v256enc)

cpdef b64v256dec(bytes input_):
    if cpu_set < 0x60: raise InvalidCPUError("avx2 is not supported")
    return _b64dec(input_, tb64v256dec)

# short strings
cpdef b64v256enc_short(bytes input_):
    if cpu_set < 0x60: raise InvalidCPUError("avx2 is not supported")
    return _b64enc(input_, _tb64v256enc)

cpdef b64v256dec_short(bytes input_):
    if cpu_set < 0x60: raise InvalidCPUError("avx2 is not supported")
    return _b64dec(input_, _tb64v256dec)

# avx512_vbmi
cpdef b64v512enc(bytes input_):
    if cpu_set < 0x800: raise InvalidCPUError("avx512 is not supported")
    return _b64enc(input_, tb64v512enc)

cpdef b64v512dec(bytes input_):
    if cpu_set < 0x800: raise InvalidCPUError("avx512 is not supported")
    return _b64dec(input_, tb64v512dec)


# == Cython helpers for encode/decode == #

cdef bytes _b64enc(bytes input_, TB64FUNC transform_func):
    # calculate the length of the encoded output buffer
    cdef size_t inlen = len(input_)      
    cdef size_t outlen = tb64enclen(inlen)
    # run the transformation
    return _transform(input_, transform_func, inlen, outlen)


cdef bytes _b64dec(bytes input_, TB64FUNC transform_func):
    # calculate the length of the decoded output buffer
    cdef size_t inlen = len(input_)
    cdef size_t outlen = tb64declen(<uchar*> input_, inlen)
    if outlen == 0 and inlen != 0:
        raise ValueError("Invalid input")
    # run the transformation
    return _transform(input_, transform_func, inlen, outlen)


cdef bytes _transform(bytes input_, TB64FUNC transform_func, size_t inlen, size_t outlen):
    cdef uchar* transformed_indata = <uchar*> malloc(outlen)
    
    # Check if memory allocation was successful
    if transformed_indata == NULL:
        raise MemoryError("Failed to allocate memory for transformed data.")
    
    # Use the transformation function and store its return value
    cdef size_t size = transform_func(<uchar*> input_, inlen, transformed_indata)
    
    # Check if the transformation function worked correctly
    if size == 0 and inlen != 0:
        free(transformed_indata)
        raise ValueError("Transformation failed. Invalid input or buffer error.")
    
    # Convert the transformed data to bytes
    cdef bytes transformed_data = bytes(transformed_indata[:size])
    
    # Free the allocated memory
    free(transformed_indata)
    
    return transformed_data
