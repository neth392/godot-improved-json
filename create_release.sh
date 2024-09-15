version=$(grep -oP '(?<=version=").*(?=")' addons/godot-improved-json/plugin.cfg)

git archive --format zip --output ./godot-improved-json-v$version.zip main