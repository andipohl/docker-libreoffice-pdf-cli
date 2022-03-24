FROM debian:bullseye

# Disable prompts on apt-get install
ENV DEBIAN_FRONTEND noninteractive

# include backport-repo
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends software-properties-common \
    && add-apt-repository 'deb [arch=amd64] https://deb.debian.org/debian bullseye-backports main contrib non-free'

# Install latest stable LibreOffice
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends -t bullseye-backports \
        libreoffice libreoffice-java-common \
        default-jre \
        fonts-opensymbol \
            hyphen-fr \
            hyphen-de \
            hyphen-en-us \
            hyphen-it \
            hyphen-ru \
            fonts-dejavu \
            fonts-dejavu-core \
            fonts-dejavu-extra \
            fonts-droid-fallback \
            fonts-dustin \
            fonts-f500 \
            fonts-fanwood \
            fonts-freefont-ttf \
            fonts-liberation \
            fonts-lmodern \
            fonts-lyx \
            fonts-sil-gentium \
            fonts-texgyre \
            fonts-tlwg-purisa \
    && apt-get remove -q -y libreoffice-gnome \
    && apt -y autoremove

# Cleanup after apt-get commands
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*.deb /var/cache/apt/*cache.bin

# Create user 'converter'
RUN useradd --create-home --shell /bin/bash converter \
    # Give user right to run libreoffice binary
    && chown converter:converter /usr/bin/libreoffice

USER converter
WORKDIR /home/converter

# Write stdin to 'input_file'
CMD cat - > input_file \
    # Convert 'input_file' to pdf
    && libreoffice --invisible --headless --nologo --convert-to pdf --outdir $(pwd) input_file >/dev/null 2>&1 \
    # Send converted file to stdout
    && cat input_file.pdf
