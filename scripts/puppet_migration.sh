git grep -l 'gitlab.swisscloud.io'
#git grep -l 'gitlab.swisscloud.io' | xargs sed -i '' -e 's/original_text/new_text/g'
# Add and commit
(git status --porcelain | wc -l | grep -qE '^0') || (git add --all && git commit -m 'Migration update')
