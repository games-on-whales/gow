interface Assets {
	GetBytes(...args : any[]):Promise<any>
	GetDataUri(...args : any[]):Promise<any>
	GetNumbers(...args : any[]):Promise<any>
	GetString(...args : any[]):Promise<any>
	WailsInit(...args : any[]):Promise<any>
}
interface Containers {
	InstallContainer(...args : any[]):Promise<any>
	RemoveContainer(...args : any[]):Promise<any>
	StartContainer(...args : any[]):Promise<any>
	StopContainer(...args : any[]):Promise<any>
	WailsInit(...args : any[]):Promise<any>
	WailsShutdown(...args : any[]):Promise<any>
}

interface Backend {
	Containers: Containers
	Assets: Assets
}

declare global {
	interface Window {
		backend: Backend;
	}
}
export {};