pragma solidity <0.8.9;

contract module1 {
    
    struct user {
        bytes32 login;
        bytes32 password;
        bool admin_status;
        bool seller_status;
        bool buyer_status;
    }
    
    struct Bank {
        bytes32 login;
        bytes32 password;
    }
    
    struct magazin {
        bytes32 login;
        bytes32 password;
        string city;
        
    }
    
    struct otsiv {
        uint id;
        address giver;
        string otsiv_user;
        uint plus;
        uint less;
    }
    
    struct Application {
        uint id;
        address user;
        address magazin;
        bool change_rule;
        bool status_application;
        bool status_complited;
    }
    
    struct Application_zaim {
        uint id;
        address magazin;
        bool status_application;
        bool status_complited;
        bool returned_status;
    }
    
    address bank = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    
    mapping (address => user) public true_user;
    
    mapping (address => address) public magazin_worker;
    mapping (address => magazin) public true_magazin;
    mapping (address => bool) public magazin_status;
    
    
    mapping (address => Bank) public true_bank;
    mapping (address => bool) public bank_status;
    
    
    Application[] public applications;
    Application_zaim[] public application_zaim;
    
    constructor() {
        
    }
    
    function register_user(bytes32 login, bytes32 password) public {
        require(true_user[msg.sender].login == 0 && true_user[msg.sender].password == 0, "You allready in sytem.");
        true_user[msg.sender] = user(login, password, false, false, true);
    }
    
    function add_worker(address magazin, address user) public {
        require(true_user[msg.sender].admin_status == true, "only admin can change this rule.");
        require(true_user[user].login == 0 && true_user[user].password == 0, "User no register in system");
        require(magazin_status[magazin] == true, "This address is not address magazin.");
        require(magazin_worker[user] != magazin, "User allready work here.");
        magazin_worker[user] = magazin;
        true_user[user].buyer_status = false;
        true_user[user].seller_status = true;
    }
    
    function add_worker_from_application(uint id) public {
        require(true_user[msg.sender].admin_status == true, "only admin can change this rule.");
        require(applications[id].status_application == true && applications[id].status_complited == false, "This application is end.");
        if (applications[id].change_rule == true) {
            magazin_worker[applications[id].user] = applications[id].magazin;
            true_user[applications[id].user].buyer_status = false;
            true_user[applications[id].user].seller_status = true;
            applications[id].status_application == false;
            applications[id].status_complited == true;
        }
        else {
            true_user[applications[id].user].seller_status = false;
            true_user[applications[id].user].buyer_status = true;
            applications[id].status_application == false;
            applications[id].status_complited == true;
            delete magazin_worker[applications[id].user];
        }
    }
    
    function create_application(address magazin, bool up_or_down) public {
        require(true_user[msg.sender].login != 0 && true_user[msg.sender].password != 0, "You not allready in sytem.");
        require(magazin_status[magazin] == true, "This address is not address magazin.");
        require(magazin_worker[msg.sender] != magazin, "You allready work here.");
        require(get_view_application(msg.sender, magazin) == false, "You allready create this application.");
        applications.push(Application(applications.length, msg.sender, magazin, up_or_down, true, false));
        
    }
    
    function chanle_application(uint id) public {
        require(applications[id].user == msg.sender, "This is not your application.");
        require(applications[id].status_application == true && applications[id].status_complited == false, "This application is end.");
        applications[id].status_application = false;
    }
    
    function get_view_application(address user, address magazin) private view returns(bool) {
        for (uint i = 0; i < applications.length; i++) {
            if (applications[i].user == user && applications[i].magazin == magazin && applications[i].status_application == true) {
                return(true);
            }
            else {
                continue;
            }
        }
        return (false);
    }
    
    function new_magazin(address magazin_address, string memory city, bool zaim_anser) public {
        require(true_user[msg.sender].admin_status == true, "only admin can add new magazin.");
        require(true_user[magazin_address].login != 0 && true_user[magazin_address].password != 0, "User not allready in sytem.");
        require(magazin_status[magazin_address] == false, "Magazin allready in system.");
        true_magazin[magazin_address] = magazin(true_user[magazin_address].login, true_user[magazin_address].password, city);
        magazin_status[magazin_address] = true;
        if (zaim_anser == true) {
            application_zaim.push(Application_zaim(application_zaim.length, magazin_address, true, false, false));
        }
    }
    
    function create_zaim() public {
        require(magazin_status[msg.sender] == true, "Only magazins can create zaim.");
        application_zaim.push(Application_zaim(application_zaim.length, msg.sender, true, false, false));
    }
    
    function chanle_zaim(uint id) public {
        require(application_zaim[id].magazin == msg.sender, "No you create this application.");
        require(application_zaim[id].status_application == true && application_zaim[id].status_complited == false && application_zaim[id].returned_status == false);
        delete application_zaim[id];
    }
    
    function zaim_magazin(address magazin) public {
        
        
    }
    
}

