FROM python:3

ADD server .
ADD requirements.txt .
RUN pip3 install -r requirements.txt

EXPOSE 80
CMD ["python3", "./server.py"]
