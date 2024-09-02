#!/usr/bin/env bash

env -i \
  PATH="/usr/bin:/bin" \
  SHELL=/bin/bash \
  HOME="$HOME" \
  /bin/bash --noprofile --norc

