const getDependencyVersions = require('./getDependencyVersionsV2.js').getDependencyVersions;
const merge = require('./src/utils.js').merge;

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];



const getAllRequiredDependencies = (programName, version) => {
	let dependencies = {};

	let dependencyVersions = getDependencyVersions(programName, version);

	for (const [dependencyProgram, dependencyVersion] of Object.entries(dependencyVersions)) {
		if (!dependencies.hasOwnProperty(dependencyProgram)) {
			dependencies[dependencyProgram] = [];
		}
		dependencies[dependencyProgram].push(dependencyVersion);


		dependencies = merge(dependencies, getAllRequiredDependencies(dependencyProgram, dependencyVersion));
	}

	return dependencies;
}

exports.getAllRequiredDependencies = getAllRequiredDependencies;

if (fileName === scriptName) {
	(async () => {
		const programName = process.argv[2];
		const version = process.argv[3];

		const allRequiredDependencies = getAllRequiredDependencies(programName, version);
		console.log(JSON.stringify(allRequiredDependencies, null, ' '));
	})();
}