<h1 align="center">
    Turbo Base64
</h1>


<p align="center">
    <a href="https://github.com/daijro/turbobase64/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/daijro/turbobase64?color=yellow">
    </a>
    <a href="https://python.org/">
        <img src="https://img.shields.io/badge/python-3.7&#8208;3.11-blue">
    </a>
    <a href="https://github.com/cython/cython">
        <img src="https://img.shields.io/badge/language-cython-black.svg">
    </a>
    <a href="https://pypi.org/project/turbob64/">
        <img alt="PyPI" src="https://img.shields.io/pypi/v/turbob64.svg?color=orange">
    </a>
    <a href="https://ci.appveyor.com/project/daijro/turbobase64">
        <img alt="AppVeyor" src="https://ci.appveyor.com/api/projects/status/github/daijro/turbobase64?svg=true">
    </a>
    <h4 align="center">
        🚀 Lightning fast base64 encoding for Python
    </h4>
</p>


## ✨ Features

- 20-30x faster than the standard library
- Benchmarks faster than any other C base64 library
- Fastest implementation of AVX, AVX2, and AVX512 base64 encoding
- No other dependencies

<hr width=50>

## ⚡ How fast is it?

Graph generated from [benchmark.py](https://github.com/daijro/turbobase64/blob/main/benchmark.py):

<img src="https://i.imgur.com/jC3ka6e.png" width=500>

<hr width=50>

## 💻 Usage

```py
>>> import turbob64
```

This will automatically detect the fastest algorithm your CPU is capable of and use it.

### Encoding

```py
>>> turbob64.b64encode(b'Hello World!')
b'SGVsbG8gV29ybGQh'
```

### Decoding

```py
>>> turbob64.b64decode(b'SGVsbG8gV29ybGQh')
b'Hello World!'
```

<hr width=50>

### Other Functions

<details>
<summary>
Directly call CPU-specific algorithms
</summary>

Memory efficient (small lookup tables) scalar but slower version

```py
turbob64.b64senc(b'Hello World!')
turbob64.b64sdec(b'SGVsbG8gV29ybGQh')
```

Fast scalar

```py
turbob64.b64xenc(b'Hello World!')
turbo64.b64xdec(b'SGVsbG8gV29ybGQh')
```

ssse3 SIMD

```py
turbob64.b64v128enc(b'Hello World!')
turbob64.b64v128dec(b'SGVsbG8gV29ybGQh')
```

avx SIMD

```py
turbob64.b64v128aenc(b'Hello World!')
turbob64.b64v128adec(b'SGVsbG8gV29ybGQh')
```

avx2 SIMD

```py
turbob64.b64v256enc(b'Hello World!')
turbob64.b64v256dec(b'SGVsbG8gV29ybGQh')
```

avx2 SIMD (optimized for short strings)

```py
turbob64.b64v256enc_short(b'Hello World!')
turbob64.b64v256dec_short(b'SGVsbG8gV29ybGQh')
```

avx512_vbmi SIMD

```py
turbob64.b64v512enc(b'Hello World!')
turbob64.b64v512dec(b'SGVsbG8gV29ybGQh')
```

</details>

---