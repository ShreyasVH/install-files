const fs = require('fs');

(async () => {
	const getFiles = path => {
	    return fs.readdirSync(path).filter(file => !['.DS_Store'].includes(file));
	};

	const missingVersions = {};

	const excludedDirectories = [
		'.git',
		'data',
		'node_modules',
		'untested',
		'src'
	];

	const files = getFiles('./');
	const folders = files.filter(file => {
		return fs.statSync('./' + file).isDirectory() && !excludedDirectories.includes(file);
	});

	const programData = JSON.parse(fs.readFileSync('./programData.json').toString());


	for (const programName of folders) {
		// console.log(programName);
		const pathTocheck = programData[programName].path;
		const versions = getFiles('./' + programName);
		for (const version of versions) {
			const fullPath = process.env.HOME + '/programs/' + programName + '/' + version + pathTocheck;
			const osFolders = getFiles('./' + programName + '/' + version);
			if (osFolders.includes('macos') && !fs.existsSync(fullPath)) {
				// console.log(fullPath);
				if (!missingVersions.hasOwnProperty(programName)) {
					missingVersions[programName] = [];
				}

				missingVersions[programName].push(version);
			}
		}
	}

	fs.writeFileSync('missingVersions.json', JSON.stringify(missingVersions, null, ' '));

})();