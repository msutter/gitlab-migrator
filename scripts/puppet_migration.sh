find . -type f -exec sed  -i '' -e 's/gitlab\.swisscloud\.io/git.swisscloud.io/g' {} \;

# Add and commit
(git status --porcelain | wc -l | grep -qE '^0') || (git add --all && git commit -m 'Migration update')
