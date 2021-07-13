// Wails doesn't export the interfaces it generates, but typescript's
// declaration merging means if we export them here we can still use them
export interface Assets { }
export interface Containers { }

export interface Container {
    Name: string;
    Id: string;
}
