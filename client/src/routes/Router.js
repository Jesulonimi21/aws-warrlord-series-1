import { Route, Routes } from "react-router-dom"
import Home from "../Pages/Home"
import SecTestPage from "../Pages/SecTestPage"

export default function AppRouter(props){
    return(<Routes>
        <Route path="/" element={<Home />}></Route>
        <Route path="/second" element={<SecTestPage />}></Route>
        <Route path="/*" element={<div>not found</div>}></Route>
    </Routes>)
}