import React, { useState } from 'react';

type Option = {
    value: number;
    label: string;
};

type CustomDropdownProps = {
    options: Option[];
    onSelect: (value: number) => void;
    placeholder?: string;
};

const CustomDropdown: React.FC<CustomDropdownProps> = ({
    options,
    onSelect,
    placeholder = 'Select an option',
}) => {
    const [isOpen, setIsOpen] = useState(false);
    const [selected, setSelected] = useState<Option | null>(null);
    const [isExpanded, setIsExpanded] = useState(false)

    const handleDropdown = () => {
        //timeout added for fade out animation.
        if (isOpen) {
            setIsExpanded(false)
            setTimeout(()=> {
                setIsOpen(false)
            },300)
        }
        else {
            setIsExpanded(true)
            setIsOpen(true)
        }
    }

    const handleSelect = (option: Option) => {
        setSelected(option);
        setIsOpen(false);
        onSelect(option.value);
    };

    return (
        <div className='custom-dropdown'>
            <div
                className="dropdown-header"
                onClick={handleDropdown}
            >
                {selected ? selected.label : placeholder}
            </div>
            <div className={`dropdown ${isExpanded ? 'dropdown-open' : 'dropdown-closed'}`}>
                {isOpen && (
                    <ul className='dropdown-list'>
                        {options.map((option) => (
                            <li
                                key={option.value}
                                className="dropdown-item"
                                onClick={() => handleSelect(option)}
                            >
                                {option.label}
                            </li>
                        ))}
                    </ul>
                )}
            </div>
        </div>
    );
};

export default CustomDropdown;