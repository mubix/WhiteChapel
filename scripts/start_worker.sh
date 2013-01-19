#!/bin/bash
TERM_CHILD=1 QUEUE='*' rake resque:work
