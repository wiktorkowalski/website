export const SITE = {
  url: "https://wiktorkowalski.pl",
  title: "Wiktor Kowalski",
  description: "Software engineer. .NET, Node.js and AWS, with a soft spot for infrastructure.",
  author: "Wiktor Kowalski",
  blog: "https://blog.wiktorkowalski.pl",
  email: "mail@wiktorkowalski.pl",
};

// Patch panel ports = sections of the rack. `act` lights the amber LED.
export const NAV = [
  { href: "/#whoami", label: "whoami" },
  { href: "/#projects", label: "projects", act: true },
  { href: "/#log", label: "log" },
  { href: "/#blog", label: "blog", act: true },
  { href: "/#stack", label: "stack" },
  { href: "/#contact", label: "contact" },
];

// UPS LCD.
export const STATUS = {
  headline: "ONLINE",
  detail: "Happy to talk backend, cloud and infrastructure.",
};

export const SOCIALS = [
  { href: "https://github.com/wiktorkowalski", label: "GitHub" },
  { href: "https://www.linkedin.com/in/wiktor-kowalski", label: "LinkedIn" },
  { href: "https://x.com/_wiktorkowalski", label: "X" },
  { href: "https://blog.wiktorkowalski.pl", label: "Blog" },
];
