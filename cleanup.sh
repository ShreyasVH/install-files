declare -A ignored_folders

ignored_folders["docker"]=1
ignored_folders["macos"]=1
ignored_folders["node_modules"]=1
ignored_folders["src"]=1
ignored_folders["ubuntu_20_04"]=1
ignored_folders["wsl_18_04"]=1
ignored_folders["wsl_20_04"]=1


for program_dir in ./*/; do
	if [ -d "$program_dir" ]; then
	    program=$(basename "$program_dir")

	    if [[ -z "${ignored_folders["$program"]}" ]]; then
	    	echo $program
	    	for version_dir in "$program_dir"*/; do
	    		if [ -d "$version_dir" ]; then
			        version=$(basename "$version_dir")
			        echo "\t$version"
			        for os_dir in "$version_dir"*/; do
			        	if [ -d "$os_dir" ]; then
			        		os=$(basename "$os_dir")
			        		echo "\t\t$os"
			        		if [ -d "$os/$program/$version" ]; then
			        			rm -rf "$program/$version/$os"
			        		fi

			        		if [ $os = "wsl" ]; then
			        			rm -rf "$program/$version/$os"
			        		fi
			        	fi
		        	done
		        	if [[ -z $(ls -A $version_dir) ]]; then
		        		rm -rf $version_dir
		        	fi
			    fi
	    	done
	    fi
	fi

	if [[ -z $(ls -A $program_dir) ]]; then
		rm -rf $program_dir
	fi
done