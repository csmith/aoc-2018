FROM nimlang/nim

RUN apt-get update && apt-get install -y pypy

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER nobody

CMD /entrypoint.sh
VOLUME /code
