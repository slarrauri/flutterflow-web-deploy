# Usamos una imagen base de Ubuntu
FROM ubuntu:20.04

# Establecemos variables de entorno para evitar interacciones en la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalamos dependencias necesarias
RUN apt-get update && apt-get install -y \
  git \
  curl \
  unzip \
  xz-utils \
  zip \
  bash \
  openssh-client \
  && rm -rf /var/lib/apt/lists/*

# Especificamos la versión de Flutter que queremos instalar
ARG FLUTTER_VERSION=stable  # O una versión específica como "3.7.0"
ENV FLUTTER_VERSION=${FLUTTER_VERSION}

# Instalamos Flutter
RUN git clone --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /opt/flutter

# Añadimos Flutter al PATH
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Verificamos la instalación de Flutter
RUN flutter doctor

# Establecemos el directorio de trabajo
WORKDIR /app

# Comando por defecto (puede ser sobreescrito)
CMD ["bash"]