import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = {title:'سنگارا | هنر کوچک، حال خوب خانه',description:'فروشگاه سنگ مصنوعی، اکسسوری رزینی و ابزار خلق زیبایی'};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="fa" dir="rtl"><body>{children}</body></html>}
