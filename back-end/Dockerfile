FROM python:3

ADD server .
ADD requirements.txt .
RUN pip3 install -r requirements.txt

RUN pip3 install -r requirements.txt

CMD ["python3", "./server.py"]
