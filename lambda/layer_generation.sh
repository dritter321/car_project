python3.11 -m venv lambda-env
source lambda-env/bin/activate
pip install --upgrade pip
pip install --platform manylinux2014_x86_64 --target=python --implementation cp --python-version 3.11 --only-binary=:all: --upgrade pandas
zip -r pandas_layer.zip python
rm -r python
rm -r lambda-env
deactivate