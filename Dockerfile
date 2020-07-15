FROM python:3
WORKDIR /robot

COPY . .
RUN python3 -m pip install -r requirements.txt