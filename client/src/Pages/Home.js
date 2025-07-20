import { useEffect } from "react";
import "../App.css";
import { useError } from "../Components/ErrorBoundary";
import { useNavigate } from "react-router";
export default function Home(){
  let navigate = useNavigate();

    const {reportError} = useError();
    useEffect(() =>{
        
    }, [])
   

    return (<div className="">
       
           <button className="bg-blue-500 h-8 w-24 mt-8 rounded-md ml-8 text-white" onClick={()=>{
            navigate("/second")
           }}>Next Page from codebuild
               </button>
      </div> )
}
