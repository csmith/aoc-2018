FROM pypy:3

RUN pip3 install numpy

ADD docker/entrypoint.sh /entrypoint.sh
ADD 2018.ipynb /code/2018.ipynb
ADD data /code/data
ADD docker/spliterator.py /code/spliterator.py
RUN chmod +x /entrypoint.sh && \
    chown -R nobody /code/ && \
    chmod +x /code/spliterator.py

USER nobody

WORKDIR /code
RUN pypy3 /code/spliterator.py

CMD /entrypoint.sh