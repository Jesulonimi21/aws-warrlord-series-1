import {render, screen} from '@testing-library/react'
import '@testing-library/jest-dom'
import ProductCard from '../src/Components/ProductCard'


test("test that Product contains texr", async() =>{
    render(<ProductCard />)
    await screen.findByRole("heading");

    expect(screen.getByRole('heading')).toHaveTextContent('Cool')
})