for f in .*
do
    if [ f != .git ]; then
        cp "$f" ~/$f
    fi
done

