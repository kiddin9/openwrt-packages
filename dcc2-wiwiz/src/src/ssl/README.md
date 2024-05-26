# Usage

```
cmake_minimum_required(VERSION 3.0)

project(xx C)

add_subdirectory(ssl)

if(SSL_SUPPORT)
    target_link_libraries(xx PRIVATE ${SSL_TARGET})
endif()
```

```
 #ifdef SSL_SUPPORT
 #include "ssl/ssl.h"
 #endif
```

# CMake variables
```
// SSL support
SSL_SUPPORT:BOOL

// Force select MbedTLS(PolarSSL)
USE_MBEDTLS:BOOL

// Force select OpenSSL
USE_OPENSSL:BOOL

// Force select WolfSSL(CyaSSL)
USE_WOLFSSL:BOOL
```