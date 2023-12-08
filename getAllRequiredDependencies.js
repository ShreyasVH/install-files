const getDependencyVersions = require('./getDependencyVersionsV2.js').getDependencyVersions;

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

const merge = (a, b) => {
	const mergedObject = {};
	for (const key of Object.keys(a)) {
		mergedObject[key] = a[key].concat(b[key] || []);
	}

	for (const key of Object.keys(b)) {
		if (!a.hasOwnProperty(key)) {
			mergedObject[key] = b[key];
		}
	}

	for (const key of Object.keys(mergedObject)) {
		mergedObject[key] = mergedObject[key].filter((item, index) => mergedObject[key].indexOf(item) === index);
	}

	return mergedObject;
}

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