import {convertFileSrc} from "@tauri-apps/api/core";

export function getFileSrc(path:string){
    return convertFileSrc(path);
}

// Было: C:/documents/.../attachment/image.png
// Теперь asset://localhost//.../attachment/image.png
