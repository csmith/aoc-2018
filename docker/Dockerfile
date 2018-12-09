FROM nimlang/nim:alpine

RUN apk update && apk add bash

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER nobody

CMD /entrypoint.sh
VOLUME /code
