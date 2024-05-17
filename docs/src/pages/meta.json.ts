// Fetch version value fromy yaml file https://raw.githubusercontent.com/LinwoodDev/Butterfly/nightly/app/pubspec.yaml
const nightlyUrl =
  "https://raw.githubusercontent.com/LinwoodDev/Butterfly/nightly/app/pubspec.yaml";
const nightlyVersion = await fetch(nightlyUrl)
  .then((res) => res.text())
  .then((text) => {
    const regex = /^version:\s(.+)\+(.+)$/gm;
    const match = regex.exec(text);
    return match?.[1];
  });

// stable
const stableUrl =
  "https://raw.githubusercontent.com/LinwoodDev/Butterfly/stable/app/pubspec.yaml";
const stableVersion = await fetch(stableUrl)
  .then((res) => res.text())
  .then((text) => {
    const regex = /^version:\s(.+)\+(.+)$/gm;
    const match = regex.exec(text);
    return match?.[1];
  });

// develop
const developUrl =
  "https://raw.githubusercontent.com/LinwoodDev/Butterfly/develop/app/pubspec.yaml";
const developVersion = await fetch(developUrl)
  .then((res) => res.text())
  .then((text) => {
    const regex = /^version:\s(.+)\+(.+)$/gm;
    const match = regex.exec(text);
    return match?.[1];
  });

// main
const mainUrl =
  "https://raw.githubusercontent.com/LinwoodDev/Butterfly/main/app/pubspec.yaml";
const mainVersion = await fetch(mainUrl)
  .then((res) => res.text())
  .then((text) => {
    const regex = /^version:\s(.+)\+(.+)$/gm;
    const match = regex.exec(text);
    return match?.[1];
  });

export function GET() {
  return new Response(JSON.stringify({
    version: {
      nightly: nightlyVersion,
      stable: stableVersion,
      develop: developVersion,
      main: mainVersion,
    },
  }));
}
