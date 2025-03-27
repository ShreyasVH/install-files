const fs = require('fs');

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

const parseReleaseDate = releaseDateString => {
	const releaseDateParts = releaseDateString.split('/');
	const releaseDate = new Date(releaseDateParts[2], releaseDateParts[1] - 1, releaseDateParts[0]);
	return releaseDate;
};

const getDependencyVersions = (program, version) => {
	const versionMapFilePath = 'versionMap.json';
	const versionMap = JSON.parse(fs.readFileSync(versionMapFilePath).toString());
	const staticVersionMapFilePath = 'staticVersionMap.json';
	const staticVersionMap = JSON.parse(fs.readFileSync(staticVersionMapFilePath).toString());

	let dependencies = {};
	if(versionMap.hasOwnProperty(program) && versionMap[program].hasOwnProperty(version))
	{
		dependencies = versionMap[program][version];
	}
	if(staticVersionMap.hasOwnProperty(program) && staticVersionMap[program].hasOwnProperty(version))
	{
		dependencies = Object.assign(dependencies, staticVersionMap[program][version]);
	}

	return dependencies;
};

exports.getDependencyVersions = getDependencyVersions;

if (fileName === scriptName) {
	(async () => {
		const requiredProgram = process.argv[2];
		const requiredVersion = process.argv[3];
		const dependencyVersions = getDependencyVersions(requiredProgram, requiredVersion);
		console.log(JSON.stringify(dependencyVersions, null, ' '));
	})();
}