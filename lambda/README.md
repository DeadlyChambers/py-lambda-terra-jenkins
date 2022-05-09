# Test Python
If you run the function locally, the __main__ function will be called when you run
```
python3 send_sns.py
```
Running in this fashion should use the creds you got from `aws-creds` so be sure you've gotten fresh creds

# Package Python Lambda Function
Ensure you have [pipenv](https://buildmedia.readthedocs.org/media/pdf/pipenv/latest/pipenv.pdf) installed and you are on the same level as the package.py file
```
pipenv run python3 package.py
```
The zip file created will be what you need to deploy with the terraform script

# Switching to Distribution Best Practices
Recommended build and package tools
`python -m pip install setuptools wheel twine`
