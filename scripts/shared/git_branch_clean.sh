#!/bin/bash
echo "Starting branch cleanup utility"
echo ""

# Define protected/main branches
MAIN_BRANCHES="master main dev devel develop development stage"

read -p "Do you want to automatically clean merged branches first? (y/n) " auto_clean
if [ "$auto_clean" = "y" ]; then
    echo "Cleaning merged branches..."
    for mainBranch in $MAIN_BRANCHES; do 
        if git rev-parse --verify "$mainBranch" >/dev/null 2>&1; then 
            git branch --merged $mainBranch | egrep -v "(^\*|$MAIN_BRANCHES)" | xargs git branch -d 2>/dev/null
        fi
    done
    echo "Automatic cleanup complete!"
    echo "----------------------------------------"
fi

echo "Starting interactive branch review..."
echo "Commands: y (delete), n (keep), q (quit)"
echo ""

git branch | grep -v "^\*" | egrep -v "($MAIN_BRANCHES)" | while IFS= read -r branch; do
    # Remove leading spaces from branch name
    branch=$(echo "$branch" | tr -d '[:space:]')
    
    # Show branch details
    echo "Branch: $branch"
    echo "Last commit:"
    git log -1 --pretty=format:"%h %s%n🕒 Created: %cd (%cr)%n👤 Author: %an" --date=format:"%Y-%m-%d %H:%M:%S" "$branch"
    echo ""
    
    # Check if branch has remote tracking branch gone
    if git branch -vv | grep "^  $branch" | grep -q ": gone]"; then
        echo "⚠️  Remote tracking branch is gone"
    fi
    
    # Check if branch is merged to any main branch
    for mainBranch in $MAIN_BRANCHES; do
        if git rev-parse --verify "$mainBranch" >/dev/null 2>&1; then
            if git branch --merged $mainBranch | grep -q "^  $branch"; then
                echo "✅ Merged into $mainBranch"
            fi
        fi
    done
    
    echo ""
    while true; do
        read -p "Delete this branch? (y/n/q) " answer < /dev/tty
        case $answer in
            [Yy]* ) 
                git branch -D "$branch"
                break
                ;;
            [Nn]* ) 
                break
                ;;
            [Qq]* ) 
                echo "Quitting script..."
                exit 0
                ;;
            * ) 
                echo "Please answer y (delete), n (keep), or q (quit)"
                ;;
        esac
    done
    echo "----------------------------------------"
done

echo "Branch review complete!"
