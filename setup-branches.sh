#!/bin/bash

# Branch Setup Script
# Run this after creating a repository from the template to ensure branches share commit history

set -e  # Exit on any error

echo "🔧 Setting up branch structure with shared history..."
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Ensure we're on develop branch (base branch)
echo "📍 Switching to develop branch..."
git checkout develop 2>/dev/null || {
    echo "❌ Error: 'develop' branch not found"
    exit 1
}

# Pull latest changes
echo "⬇️  Pulling latest changes..."
git pull origin develop

# Delete existing branches (both local and remote)
echo ""
echo "🗑️  Removing existing branches..."
for branch in release prod; do
    # Delete local branch if it exists
    if git show-ref --verify --quiet refs/heads/$branch; then
        echo "  - Deleting local branch: $branch"
        git branch -D $branch 2>/dev/null || true
    fi
    
    # Delete remote branch if it exists
    if git ls-remote --exit-code --heads origin $branch > /dev/null 2>&1; then
        echo "  - Deleting remote branch: $branch"
        git push origin --delete $branch 2>/dev/null || true
    fi
done

echo ""
echo "✨ Creating new branches from develop..."

# Create release branch
echo "  - Creating release branch..."
git checkout develop
git checkout -b release
git push -u origin release

# Create prod branch
echo "  - Creating prod branch..."
git checkout develop
git checkout -b prod
git push -u origin prod

# Return to original branch or develop
if [ "$CURRENT_BRANCH" = "develop" ] || [ "$CURRENT_BRANCH" = "release" ] || [ "$CURRENT_BRANCH" = "prod" ]; then
    git checkout $CURRENT_BRANCH 2>/dev/null || git checkout develop
else
    git checkout develop
fi

echo ""
echo "✅ Branch setup complete!"
echo ""
echo "📊 Branch structure:"
git log --oneline --graph --all --decorate -5
echo ""
echo "🎉 All branches now share commit history and can be merged!"
echo ""
echo "Recommended workflow:"
echo "  • Feature development → develop"
echo "  • Staging/testing → release (merge from develop)"
echo "  • Production → prod (merge from release)"
