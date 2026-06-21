const puppeteer = require('puppeteer');
const fs = require('fs');

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

const getAllVersionsMainFromHTML = () => {
	return [...document.querySelector('table').querySelectorAll('a')].map(a => ({ version: a.innerText, link: a.href })).slice(1);
};

const getAllVersionsFromHTML = () => {
	const versionElements = [...document.querySelectorAll('.download-panel')];

	const versions = [];

	for (const ele of versionElements) {
		const releaseDateElement = ele.querySelector('dl.release-date > dd')
		const releaseDateText = releaseDateElement.innerText;
		// console.log(releaseDateText);

		const subVersions = [...ele.querySelectorAll('h3')].filter(e => e.innerText.includes('SDK')).map(e => e.innerText);
		// console.log(JSON.stringify(subVersions));

		for (const subVersion of subVersions) {
			const subVersionText = subVersion.replace('SDK ', '');
			versions.push({
				version: subVersionText,
				releaseDateString: releaseDateText
			});
		}
	}

	return versions;
};

const filterVersions = (allVersions) => {
	return allVersions.filter(item => {
		const regex = new RegExp("^(\\d+\\.\\d+\\.\\d+)$");
		const matches = item.version.match(regex);
		return matches !== null && matches[0] === item.version;
	});
};


const getAllVersions = async () => {
	const baseUrl = 'https://dotnet.microsoft.com/en-us/download/dotnet';
	const program = 'dotnet-core';

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

    console.log(baseUrl);
	const page = await browser.newPage();
    await page.goto(baseUrl, {
        waitUntil: 'networkidle2',
        timeout: 0
    });
    page.on('console', msg => console.log('PAGE LOG:', msg.text()));

    const versionsResponse = (await page.evaluate(getAllVersionsMainFromHTML)).reverse();
    // console.log(versionsResponse);

    for (const versionDetails of versionsResponse) {
    	const subVersionUrl = versionDetails.link;
    	console.log(subVersionUrl);

    	await page.goto(subVersionUrl, {
    	    waitUntil: 'networkidle2',
    	    timeout: 0
    	});
    	page.on('console', msg => console.log('PAGE LOG:', msg.text()));

    	const subVersions = await page.evaluate(getAllVersionsFromHTML);

    	const existingVersions = allVersions.map(item => item.version);

    	const newVersions = subVersions.filter(item => !existingVersions.includes(item.version));

    	allVersions = newVersions.concat(allVersions);
    }

	await page.close();

    await browser.close();

    
    versionHistory[program] = filterVersions(allVersions);
    fs.writeFileSync(versionHistoryFilePath, JSON.stringify(versionHistory, null, ' '));

    
    allVersionsData[program] = allVersions;
    fs.writeFileSync(allVersionsFilePath, JSON.stringify(allVersionsData, null, ' '));
};

exports.getAllVersions = getAllVersions;

if (fileName === scriptName) {
	(async () => {
		await getAllVersions();
	})();
}

