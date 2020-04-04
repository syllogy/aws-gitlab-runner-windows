ARG WINDOWS_VERSION=lts-windowsservercore-1903

FROM mcr.microsoft.com/powershell:${WINDOWS_VERSION}

LABEL maintainer="Lucca Pessoa da Silva Matos - luccapsm@gmail.com" \
        org.label-schema.version="1.0.0" \
        org.label-schema.release-data="2020-04-04" \
        org.label-schema.url="https://github.com/lpmatos" \
        org.label-schema.powershell="https://docs.microsoft.com/pt-br/powershell/" \
        org.label-schema.name="AWS GitLab Runner Windows"

COPY [ "./code", "." ]

ENTRYPOINT []

CMD [ "powershell" ]
