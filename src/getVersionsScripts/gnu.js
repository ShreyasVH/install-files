const puppeteer = require('puppeteer');
const fs = require('fs');

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

const getAllVersionsFromHTML = () => {
	const versionElements = [...document.querySelectorAll('table tbody tr')].filter((ele, index) => index > 2);

	const versionDetails = versionElements.map(ele => {
		const cells = ele.children;
		const linkElement = cells[1];
		if (linkElement) {
			const versionElement = linkElement.querySelector('a');
			let version;
			let versionText;
			if (versionElement && versionElement.innerText.match(/(.*).tar.gz$/)) {
				versionText = versionElement.innerText;
				version = versionText.match(/(.*).tar.gz$/)[1];
			}

			const releaseDateElement = cells[2];
			let releaseDateString;
			if (releaseDateElement) {
				releaseDateString = releaseDateElement.innerText.trimEnd();
			}

			return {
				version,
				releaseDateString
			};
		}
	})
	.filter(item => item && item.version);
	return {
		versions: versionDetails
	};
};

const getVersionString = (programName, programDetails, rawVersionString) => {
	let versionString = rawVersionString.replace(programName, '').replaceAll(/[a-zA-Z-]/g, '');
	if (versionString[0] === '_') {
		versionString = versionString.substring(1);
	}
	versionString = versionString.replaceAll('_', '.');
	return versionString;
}

const filterVersions = (programName, programDetails, allVersions) => {
	let filteredVersions = allVersions.filter(item => {
		const regex = new RegExp(programDetails.versionRegex);
		const matches = item.version.match(regex);
		return matches !== null && matches[0] === item.version;
	});

	return filteredVersions.map(item => ({
		version: getVersionString(programName, programDetails, item.version),
		releaseDateString: item.releaseDateString
	}));
};



const getAllVersions = async (program, url) => {
	const programData = JSON.parse(fs.readFileSync('programData.json').toString());
    const versionHistoryFilePath = 'versionHistory.json';
    const versionHistory = JSON.parse(fs.readFileSync(versionHistoryFilePath).toString());

    const allVersionsFilePath = 'allVersions.json';
    const allVersionsData = JSON.parse(fs.readFileSync(allVersionsFilePath).toString());

	const browser  = await puppeteer.launch({
		headless: 'shell'
	});

    let allVersions = ((allVersionsData.hasOwnProperty(program)) ? allVersionsData[program] : []);
    const originalVersionLength = allVersions.length;

    console.log(allVersions.length);

    console.log(url);
	const page = await browser.newPage();
    await page.goto(url, {
        waitUntil: 'networkidle2',
        timeout: 0
    });
    page.on('console', msg => console.log('PAGE LOG:', msg.text()));

	const versionsResponse = await page.evaluate(getAllVersionsFromHTML);

	const existingVersions = allVersions.map(item => item.version);

	const newVersions = versionsResponse.versions.filter(item => !existingVersions.includes(item.version));

	allVersions = newVersions.concat(allVersions);
	console.log(allVersions);
	await page.close();

    await browser.close();


    
    versionHistory[program] = filterVersions(program, programData[program], allVersions);
    fs.writeFileSync(versionHistoryFilePath, JSON.stringify(versionHistory, null, ' '));

    
    allVersionsData[program] = allVersions;
    fs.writeFileSync(allVersionsFilePath, JSON.stringify(allVersionsData, null, ' '));
};

exports.getAllVersions = getAllVersions;

if (fileName === scriptName) {
	(async () => {
		const program = process.argv[2];
		const tagsUrl = process.argv[3];
		await getAllVersions(program, tagsUrl);
	})();
}

