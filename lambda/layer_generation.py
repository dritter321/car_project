python3.11 -m venv lambda-env
source lambda-env/bin/activate
pip install --platform manylinux2014_x86_64 --target=my-lambda-function --implementation cp --python-version 3.11 --only-binary=:all: --upgrade pandas
zip -r pandas.zip python