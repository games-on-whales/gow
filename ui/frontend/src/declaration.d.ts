declare module "*.css" {
    const mapping: Record<string, string>;
    export default mapping;
}

declare module "*.png" {
    const value: any;
    export default value;
}
