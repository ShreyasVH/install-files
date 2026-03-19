const puppeteer = require('puppeteer');
const fs = require('fs');

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

const getAllVersionsFromHTML = () => {
	const versionElements = [...document.querySelectorAll('.Box-row')];

	const versionDetails = versionElements.map(ele => {
		const versionElement = ele.querySelector('h2 a');
		let version;
		if (versionElement) {
			version = versionElement.innerText;
		}

		const releaseDateElement = ele.querySelector('relative-time');
		let releaseDateString;
		if (releaseDateElement) {
			releaseDateString = releaseDateElement['datetime'];
		}

		return {
			version,
			releaseDateString
		};
	});

	const paginationChildren = document.querySelector('.pagination').children;
	const hasMoreVersions = paginationChildren[1].tagName === 'A';

	return {
		versions: versionDetails,
		hasMoreVersions
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



const getAllVersions = async (program, baseUrl) => {
	const programData = JSON.parse(fs.readFileSync('programData.json').toString());
    const versionHistoryFilePath = 'versionHistory.json';
    const versionHistory = JSON.parse(fs.readFileSync(versionHistoryFilePath).toString());

    const allVersionsFilePath = 'allVersions.json';
    const allVersionsData = JSON.parse(fs.readFileSync(allVersionsFilePath).toString());

	const browser  = await puppeteer.launch({
		headless: 'shell',
		args: [
		    '--no-sandbox',
		    '--disable-setuid-sandbox',
		    '--ignore-certificate-errors'
		]
	});

    let allVersions = ((allVersionsData.hasOwnProperty(program)) ? allVersionsData[program] : []);
    const originalVersionLength = allVersions.length;

    console.log(allVersions.length);

    const baseUrlParts = baseUrl.split('?');

    let hasMoreVersions = true;
    let url = baseUrl;
    while (true) {
    	console.log(url);
    	const page = await browser.newPage();
	    await page.goto(url, {
	        waitUntil: 'networkidle2',
	        timeout: 0
	    });
	    page.on('console', msg => console.log('PAGE LOG:', msg.text()));

    	const versionsResponse = await page.evaluate(getAllVersionsFromHTML);
    	// console.log(versionsResponse);

    	const existingVersions = allVersions.map(item => item.version);
    	const existingVersionsReached = versionsResponse.versions.some(item => existingVersions.includes(item.version));

    	const newVersions = versionsResponse.versions.filter(item => !existingVersions.includes(item.version));
    	// console.log(newVersions);

    	if (originalVersionLength === 0) {
    		allVersions = allVersions.concat(newVersions);
    	} else {
    		allVersions = newVersions.concat(allVersions);
    	}
    	// console.log('batch versions obtained');
    	hasMoreVersions = hasMoreVersions && versionsResponse.hasMoreVersions;
    	if (hasMoreVersions && !existingVersionsReached) {
    		url = baseUrlParts[0] + '?after=' + encodeURIComponent(versionsResponse.versions[versionsResponse.versions.length - 1].version);
    	} else {
    		break;
    	}
    	await page.close();
    }

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

