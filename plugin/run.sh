LLAMA_DIRECTORY_PATH="/home/nicholas/Desktop/python/localGPT" #set directory
cd $LLAMA_DIRECTORY_PATH
args_strings=""
for arg in "@"; do
	args_string="$args_string $arg"
done
if [ -z $CONFIG ]; then
	CONFIG="-n 512"
	echo "running with default configurations"
else
	echo "running with users configurations"
fi
echo "prompting model with: $args_string"
cmd="" #configure commands with args_string being text inputed from VIM
eval("$cmd")
