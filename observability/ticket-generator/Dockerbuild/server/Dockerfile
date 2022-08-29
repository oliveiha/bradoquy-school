FROM python:3.7.1-alpine
RUN python -m pip install flask
COPY server.py /
EXPOSE 8080
CMD ["python", "/server.py"]
