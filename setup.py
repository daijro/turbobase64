from distutils.core import setup, Extension
from Cython.Build import cythonize


setup(
    name='turbob64',
    version='1.0.0',
    description='Cython bindings for Turbo Base64',
    author='daijro',
    package_data={'': ['src/turbob64.h']},
    setup_requires=["cython"],
    ext_modules=cythonize(
        [
            Extension(
                'turbob64',
                ['src/turbob64.pyx'],
                extra_link_args=['src/lib/libtb64.a'],
                extra_compile_args=['/O3', '/fp:fast', '/arch:AVX', '/arch:AVX2', '/arch:AVX512'],
            )
        ],
        language_level=3,
    ),
)
