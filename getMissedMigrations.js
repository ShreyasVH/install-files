const fs = require('fs');
const os = require('os');

const programData = JSON.parse(fs.readFileSync('programData.json').toString())

const getFiles = path => {
    return fs.readdirSync(path).filter(file => !['.DS_Store'].includes(file));
};

const getFolders = (path, baseFolder) => {
	const files = getFiles(path);
	return files.filter(file => {
		return fs.statSync(path + '/' + file).isDirectory() && (!baseFolder || !excludedDirectories.includes(file));
	});
}

const missingVersions = {};

const excludedDirectories = [
	'.git',
	'data',
	'node_modules',
	'untested',
	'src',
	'macos',
	'wsl_18_04',
	'wsl_20_04',
	'wsl_22_04',
	'wsl_24_04',
	'docker'
];


const programs = getFolders('./', true);

const missedMigrations = {};

for (const program of programs) {
	const versionFolders = getFolders(program);
	for (const version of versionFolders) {
		const osFolders = getFolders(program + '/' + version);
		for (const os of osFolders) {
			if (os !== process.env.OS_FOLDER) {
				continue
			}
			const newPath = os + '/' + program + '/' + version + '/install.sh';
			const dockerPath = 'docker/' + program + '/' + version + '/install.sh';
			if (!fs.existsSync(newPath) && !fs.existsSync(dockerPath)) {
				if (!missedMigrations.hasOwnProperty(os)) {
					missedMigrations[os] = {};
				}

				if (!missedMigrations[os].hasOwnProperty(program)) {
					missedMigrations[os][program] = [];
				}

				missedMigrations[os][program].push(version);
			}
		}
	}
}


fs.writeFileSync('missedMigrations.json', JSON.stringify(missedMigrations, null, ' '));