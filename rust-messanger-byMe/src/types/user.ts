export interface User{
    id: number;
    user_name: string;
    display_name: string;
    avatar_path: string | null;
    status: string;
    created_at: string;
}
export interface ProfileUpdate{
    displayMame: string;
    status: string;
}