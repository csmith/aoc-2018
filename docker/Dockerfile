FROM pypy:3

RUN pip3 install numpy

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER nobody

CMD /entrypoint.sh
VOLUME /code
