#!/bin/bash

cue import /workspace/.meta.yaml -l '"d2"' -o /workspace/oam/meta.cue
cue import /workspace/gp/targets/oam/target.yaml -l '"target"' -o /workspace/oam/target.cue
cat /workspace/oam/meta.cue /workspace/oam/target.cue /workspace/gp/targets/oam/napptive.cue > /workspace/oam/final.cue
cue export /workspace/oam/final.cue --out yaml  -e OAM -o /workspace/oam/oam.yaml
rm /workspace/oam/meta.cue /workspace/oam/target.cue /workspace/oam/final.cue
