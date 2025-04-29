const getDependencyVersions = require('./getDependencyVersionsV2.js').getDependencyVersions;
const merge = require('./src/utils.js').merge;

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];



const updateDependencyTree = (programName, version, dependencyTree) => {
	let dependencyVersions = getDependencyVersions(programName, version);

	for (const [dependencyProgram, dependencyVersion] of Object.entries(dependencyVersions)) {
		updateDependencyTree(dependencyProgram, dependencyVersion, dependencyTree);
		dependencyTree.push(dependencyProgram + '_' + dependencyVersion);
	}
}

exports.updateDependencyTree = updateDependencyTree;

if (fileName === scriptName) {
	(async () => {
		const programName = process.argv[2];
		const version = process.argv[3];

		let dependencyTree = [];
		updateDependencyTree(programName, version, dependencyTree);
		dependencyTree.push(programName + '_' + version);

		dependencyTree = dependencyTree.filter((item, index) => dependencyTree.indexOf(item) === index);

		console.log(JSON.stringify(dependencyTree, null, ' '));
	})();
}