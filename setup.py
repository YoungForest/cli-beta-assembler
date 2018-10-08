# -*- coding: utf-8 -*-

from distutils.core import setup

NAME = 'annotation_exporter'
VERSION = '1.0'
URL = 'https://github.com/waliens/cli-beta-assembler'
AUTHOR = "Romain Mormont"
AUTHOR_EMAIL = "r.mormont[_at_]uliege.be"
DESCRIPTION = 'Parser, assembler and simulator for beta assembly'
with open('README.md') as f:
    LONG_DESCRIPTION = f.read()


if __name__ == '__main__':
    setup(name=NAME,
          version=VERSION,
          author=AUTHOR,
          author_email=AUTHOR_EMAIL,
          url=URL,
          description=DESCRIPTION,
          long_description=LONG_DESCRIPTION,
          platforms='any',
          install_requires=['antlr4-python3-runtime'],
          packages=['beta'])