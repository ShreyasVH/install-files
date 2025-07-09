const getAllRequiredDependencies = require('./getAllRequiredDependencies.js').getAllRequiredDependencies;

const fs = require('fs');

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

const getMissingInslallFiles = (programName, version) => {
	const allRequiredDependencies = getAllRequiredDependencies(programName, version);

	const missingInstallFiles = {};

	for (const [program, versions] of Object.entries(allRequiredDependencies)) {
		for (const requiredVersion of versions) {
			const installFilePath = process.env.HOME + '/workspace/myProjects/install-files/' + process.env.OS_FOLDER + '/' + program + '/' + requiredVersion + '/install.sh';
			if (!fs.existsSync(installFilePath)) {
				if (!missingInstallFiles.hasOwnProperty(program)) {
					missingInstallFiles[program] = [];
				}
				missingInstallFiles[program].push(requiredVersion);
			}
		}
	}

	// console.log(JSON.stringify(missingInstallFiles, null, ' '));

	fs.writeFileSync('missingInstallFiles.json', JSON.stringify(missingInstallFiles, null, ' '));
	return missingInstallFiles;
}

exports.getMissingInslallFiles = getMissingInslallFiles;


if (fileName === scriptName) {
	(async () => {
		const programName = process.argv[2];
		const version = process.argv[3];

		console.log(JSON.stringify(getMissingInslallFiles(programName, version), null, ' '));
	})();
}